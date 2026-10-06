import { useMemo } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Sacrament = {
  name: string;
  description: string;
  favor_cost: number;
  required_tier: number;
  needs_consecration: boolean;
  can_perform: boolean;
  ref: string;
};

type Data = {
  favor: number;
  max_favor: number;
  tier: number;
  max_tier: number;
  consecrated: boolean;
  sacraments: Sacrament[];
};

export const OccultAltar = () => {
  return (
    <Window width={520} height={520}>
      <Window.Content>
        <AltarDisplay />
      </Window.Content>
    </Window>
  );
};

const AltarDisplay = () => {
  const { act, data } = useBackend<Data>();

  const visibleSacraments = useMemo(
    () =>
      data.sacraments.filter(
        (sacrament) => sacrament.required_tier <= data.tier,
      ),
    [data.sacraments, data.tier],
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <AltarStatus />
      </Stack.Item>

      <Stack.Item grow>
        <Section title="Sacraments" fill scrollable>
          {visibleSacraments.length ? (
            visibleSacraments.map((sacrament) => (
              <SacramentButton
                key={sacrament.ref}
                sacrament={sacrament}
                onClick={() => act('choose_sacrament', { ref: sacrament.ref })}
              />
            ))
          ) : (
            <Stack align="center" justify="center" fill>
              <Stack.Item color="label">
                No sacraments are available.
              </Stack.Item>
            </Stack>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const AltarStatus = () => {
  const { data } = useBackend<Data>();

  return (
    <Section title="Altar">
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>Favor</Stack.Item>
            <Stack.Item>
              <Box bold>
                {Math.floor(data.favor)} / {data.max_favor}
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>

        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>Tier</Stack.Item>
            <Stack.Item>
              <Box bold>
                {data.tier} / {data.max_tier}
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>

        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>Consecration</Stack.Item>
            <Stack.Item>
              <Box bold color={data.consecrated ? 'good' : 'bad'}>
                {data.consecrated ? 'Consecrated' : 'Unconsecrated'}
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SacramentButton = (props: {
  sacrament: Sacrament;
  onClick: () => void;
}) => {
  const { sacrament, onClick } = props;
  const requirements: string[] = [];

  if (sacrament.required_tier > 0) {
    requirements.push(`Tier ${sacrament.required_tier}`);
  }

  if (sacrament.needs_consecration) {
    requirements.push('Consecrated');
  }

  return (
    <Button fluid disabled={!sacrament.can_perform} onClick={onClick} mb={1}>
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow textAlign="left">
              <Box bold>{sacrament.name}</Box>
            </Stack.Item>
            <Stack.Item>
              <Box color={sacrament.can_perform ? 'good' : 'bad'}>
                {Math.floor(sacrament.favor_cost)} Favor
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>

        {sacrament.description && (
          <Stack.Item textAlign="left">
            <Box color="label">{sacrament.description}</Box>
          </Stack.Item>
        )}

        {!!requirements.length && (
          <Stack.Item textAlign="left">
            <Box color="label">Requires: {requirements.join(' · ')}</Box>
          </Stack.Item>
        )}
      </Stack>
    </Button>
  );
};
